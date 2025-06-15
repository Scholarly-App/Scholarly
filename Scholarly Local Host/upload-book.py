from flask import Flask, request, jsonify
import fitz  # PyMuPDF
import re
import string

app = Flask(__name__)

# Helper functions to sanatize text
def sanitize_key(key):
    key = re.sub(r'[.$#\[\]/]', '_', key)
    key = re.sub(r'[{}]', '_', key)
    key = key.translate(str.maketrans('', '', string.punctuation))
    return key.strip()


#Function to extract text from pages
def extract_text_from_pages(pdf, start_page, end_page):
    text = ""
    for page_num in range(start_page - 1, end_page):
        page = pdf.load_page(page_num)
        text += page.get_text("text")
    return text.strip()



def insert_entry_dual(roadmap_text, roadmap_no_text, levels, title, start_page, end_page, text):
    sanitized_title = sanitize_key(title)

    def add_to_roadmap(roadmap, include_text):
        current_level = roadmap
        for level in levels[:-1]:
            sanitized_level = sanitize_key(level)
            if sanitized_level not in current_level:
                current_level[sanitized_level] = {"sub-heading": {}}
            current_level = current_level[sanitized_level]["sub-heading"]
        
        #Including Start and End Pages
        current_level[sanitized_title] = {
            "start_page": start_page,
            "end_page": end_page,
            "sub-heading": {}
        }
        if include_text:
            current_level[sanitized_title]["text"] = text if text else "null"
    
    add_to_roadmap(roadmap_text, include_text=True)
    add_to_roadmap(roadmap_no_text, include_text=False)
    

#Function to clean raodmap
def clean_roadmap(roadmap, non_heading_terms):
    sanitized_terms = [sanitize_key(term.lower()) for term in non_heading_terms]

    def contains_non_heading_term(key):
        return any(term in key.lower() for term in sanitized_terms)

    cleaned_roadmap = {
        key: value for key, value in roadmap.items() if not contains_non_heading_term(key)
    }
    return cleaned_roadmap


def generate_roadmap(file_stream):
    roadmap_with_text = {}
    roadmap_without_text = {}
    stack = []
    #Keywords not include in heading in the roadmap
    non_heading_terms = (
        "contents", "table of contents", "index", "bibliography", "references",
        "appendix", "foreword", "preface", "acknowledgments", "glossary",
        "list of figures", "list of tables", "brief contents", "about the author",
        "afterword", "further reading", "related works", "supplementary materials",
        "notes", "credits", "errata", "dedication", "copyright", "disclaimer",
        "prologue", "epilogue", "sources", "abstract", "cover page", "title page",
        "chapter overview", "back matter", "front matter", "postscript", "cover"
    )

    with fitz.open(stream=file_stream, filetype="pdf") as pdf:
        toc = pdf.get_toc() #Getting the table of contetn from Bookmarks
        for i, entry in enumerate(toc):
            level, title, start_page = entry
            #Calculating start and end pages
            if i + 1 < len(toc):
                end_page = toc[i + 1][2] - 1
            else:
                end_page = pdf.page_count

            if start_page > end_page:
                end_page = start_page

            while stack and stack[-1][0] >= level:
                stack.pop()

            #Appending levels and titles
            stack.append((level, title))
            levels = [s[1] for s in stack]

            #Extracting text
            text = extract_text_from_pages(pdf, start_page, end_page)
            insert_entry_dual(roadmap_with_text, roadmap_without_text, levels, title, start_page, end_page, text)


    
    # Clean both roadmaps
    roadmap_with_text = clean_roadmap(roadmap_with_text, non_heading_terms)
    roadmap_without_text = clean_roadmap(roadmap_without_text, non_heading_terms)

    return roadmap_with_text, roadmap_without_text 


# Flask route
@app.route('/upload-book', methods=['POST'])
def upload_book():
    if 'file' not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files['file']

    try:
        roadmap1,roadmap2 = generate_roadmap(file.read())  # Generate the roadmap
        return jsonify({
            "roadmap1": roadmap1,
            "roadmap2": roadmap2
        }), 200 # Return the roadmap as JSON
    except Exception as e:
        return jsonify({"error": f"Error processing file: {str(e)}"}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)