import os
from pathlib import Path
from typing import List, Dict

# Import LangChain splitters from the dedicated package
from langchain_text_splitters import MarkdownHeaderTextSplitter, RecursiveCharacterTextSplitter


def _category_from_path(file_path: str) -> str:
    """Derive a stable category identifier from a markdown filename.

    Special case:
        ``housing.md`` → ``HOUSING_EVICTION``
    Otherwise the stem is upper‑cased.
    """
    stem = Path(file_path).stem.lower()
    special = {"housing": "HOUSING_EVICTION"}
    return special.get(stem, stem.upper())


def _split_by_header(text: str) -> List[Dict]:
    """Split markdown text into sections using MarkdownHeaderTextSplitter.

    Returns a list of dictionaries with keys:
        - "content": the section text
        - "section": the heading string (or empty if none)
    """
    # Define default header hierarchy to split on common markdown levels
    default_headers = [
        ("#", "Header 1"),
        ("##", "Header 2"),
        ("###", "Header 3"),
        ("####", "Header 4"),
    ]
    header_splitter = MarkdownHeaderTextSplitter(headers_to_split_on=default_headers)
    # The splitter returns ``Document`` objects with ``page_content`` and ``metadata``.
    docs = header_splitter.split_text(text)
    sections = []
    for doc in docs:
        heading = doc.metadata.get("heading") or doc.metadata.get("title") or ""
        sections.append({"content": doc.page_content, "section": heading})
    return sections


def chunk_markdown_file(path: str) -> List[Dict]:
    """Split a single markdown file into calibrated chunks.

    The pipeline is:
        1️⃣ Load raw markdown.
        2️⃣ Split by markdown headings (MarkdownHeaderTextSplitter).
        3️⃣ For each heading section, further split with RecursiveCharacterTextSplitter
           to obtain ~800‑character chunks with ~100‑character overlap.
    """
    with open(path, "r", encoding="utf-8") as f:
        raw_text = f.read()

    source_file = os.path.basename(path)
    category = _category_from_path(path)

    # 1️⃣ Header level split
    header_sections = _split_by_header(raw_text)

    # 2️⃣ Recursive character split for each section
    recursive_splitter = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=100)

    chunks: List[Dict] = []
    chunk_counter = 0
    for sec in header_sections:
        section_heading = sec["section"]
        # Split the section content further
        sub_docs = recursive_splitter.split_text(sec["content"])
        for sub_doc in sub_docs:
            chunks.append({
                "content": sub_doc,
                "source": source_file,
                "category": category,
                "section": section_heading,
                "chunk_index": chunk_counter,
            })
            chunk_counter += 1
    return chunks


def load_and_chunk_knowledge_base() -> List[Dict]:
    """Recursively locate all ``.md`` files under ``backend/knowledge`` and chunk them.
    Returns a flat list containing the chunks from every markdown file.
    """
    base_dir = Path(__file__).resolve().parents[2] / "knowledge"
    all_md = sorted(base_dir.rglob("*.md"))
    all_chunks: List[Dict] = []
    for md_path in all_md:
        all_chunks.extend(chunk_markdown_file(str(md_path)))
    return all_chunks


# ---------------------------------------------------------------------------
# Simple sanity‑check test (run with ``python -m backend.app.rag.chunker``)
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    chunks = load_and_chunk_knowledge_base()
    # Verify required fields are present on every chunk.
    for i, ch in enumerate(chunks):
        missing = [k for k in ["content", "source", "category", "section", "chunk_index"] if k not in ch]
        assert not missing, f"Missing keys {missing} in chunk {i}"
    print(f"[OK] Processed {len(chunks)} chunks from the knowledge base.")
    if chunks:
        example = chunks[0]
        print("--- Example chunk metadata ---")
        for k, v in example.items():
            if k == "content":
                preview = v[:75].replace("\n", " ") + ("..." if len(v) > 75 else "")
                print(f"{k}: {preview}")
            else:
                print(f"{k}: {v}")
