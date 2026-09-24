import os
import pathlib

api = os.environ["API_BASE"]
src = pathlib.Path("index.html.tpl").read_text(encoding="utf-8")
out = src.replace("${api_base}", api)
pathlib.Path("index.html").write_text(out, encoding="utf-8")
