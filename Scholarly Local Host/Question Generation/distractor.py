import nltk
from nltk.tokenize import word_tokenize
from nltk.translate.bleu_score import sentence_bleu, SmoothingFunction
from nltk import pos_tag, ne_chunk
from collections import Counter
from nltk.corpus import stopwords
from collections import OrderedDict
from sense2vec import Sense2Vec

import warnings
warnings.filterwarnings("ignore", message="floor_divide is deprecated", category=UserWarning)


#Function to calculate BLEU Scores
def character_bleu(hypothesis, reference):
    smoothing = SmoothingFunction().method1
    bleu_score = sentence_bleu([list(reference)], list(hypothesis),
                               smoothing_function=smoothing, weights=(1, 0, 0, 0))
    return bleu_score


def is_float(value):
    try:
        float(value)
        return True
    except ValueError:
        return False


#Extracting Ketwords that maybe an answer for a question
def extract_named_entities(sentence_arg):
    tokens = word_tokenize(sentence_arg)
    pos_tags = pos_tag(tokens)
    tree = ne_chunk(pos_tags)

    named_entities = []
    for subtree in tree:
        if isinstance(subtree, nltk.Tree):
            entity = " ".join([word for word, tag in subtree.leaves()])
            label = subtree.label()
            named_entities.append((entity, label))

    # Remove stop words
    stop_words = set(stopwords.words('english'))
    filtered_tokens = [word.lower() for word in tokens if word.isalnum() and word.lower() not in stop_words]

    # Extract keywords using Counter
    keywords = [word for word, count in Counter(filtered_tokens).most_common(5)]
    return named_entities, keywords


#Funtion to generate distractors
def generate_distractors(sentence, count, s2v):
    distractors = []
    answer = sentence.lower()
    answer = answer.replace(" ", "_")
    #Getting the best answer word
    sense = s2v.get_best_sense(answer)
    if not sense:
        named_ent, kwords = extract_named_entities(sentence)
        ne_list = []
        for i in range(len(named_ent)):
            ne_list.append(named_ent[i][0])
        for i in range(len(ne_list)):
            word = ne_list[i]
            word = word.replace(" ", "_")
            ne_list[i] = word

        distractors_candidates = []

        #Getting Possible Distractors
        for word_itr in ne_list:
            if len(distractors_candidates) >= count:
                break
            word = word_itr
            word = word.lower()
            sense = s2v.get_best_sense(word)
            if not sense:
                continue
            most_similar = s2v.most_similar(sense, count)
            #Get the most similar words
            for phrase, prob in most_similar:
                normalized_phrase = phrase.split("|")[0].replace("_", " ").lower()
                if prob < 0.6:
                    continue
                if normalized_phrase.lower() != word_itr.lower():
                    if character_bleu(normalized_phrase, word_itr) >= 0.5 and word_itr.isalpha():
                        continue
                    modified_sentence = sentence.lower().replace(word, normalized_phrase)
                    if modified_sentence not in distractors_candidates:
                        distractors_candidates.append(modified_sentence)
                        if len(distractors_candidates) > count:
                            break
                            
        if len(distractors_candidates) < count:
            for word_itr in kwords:
                if len(distractors_candidates) >= count:
                    break
                word = word_itr
                word = word.lower()
                sense = s2v.get_best_sense(word)
                if not sense:
                    continue
                most_similar = s2v.most_similar(sense, 3)
                for phrase, prob in most_similar:
                    normalized_phrase = phrase.split("|")[0].replace("_", " ").lower()
                    if float(prob) < 0.6:
                        continue

                    if normalized_phrase != word:
                        if character_bleu(word_itr.lower(), normalized_phrase) >= 0.5 and word_itr.isalpha():
                            continue
                        modified_sentence = sentence.lower().replace(word_itr, normalized_phrase)
                        if modified_sentence not in distractors_candidates:
                            distractors_candidates.append(modified_sentence)
                            if len(distractors_candidates) >= count:
                                break
                    elif normalized_phrase == word_itr:
                        continue
        return distractors_candidates

    else:
        most_similar = s2v.most_similar(sense, count)

        for phrase in most_similar:
            normalized_phrase = phrase[0].split("|")[0].replace("_", " ").lower()

            if normalized_phrase.lower() != answer:
                distractors.append(normalized_phrase.capitalize())

        return list(OrderedDict.fromkeys(distractors))