import subprocess, tempfile, os
os.environ["TRANSFORMERS_NO_ADVISORY_WARNINGS"] = "1"
os.environ.setdefault("TOKENIZERS_PARALLELISM", "false")
from mlx_vlm import load, generate
from mlx_vlm.prompt_utils import apply_chat_template

def capture_interactive_region():
    fd, path = tempfile.mkstemp(suffix=".png")
    os.close(fd)
    subprocess.run(["/usr/sbin/screencapture", "-i", "-s", "-x", path], check=False)
    if not os.path.exists(path) or os.path.getsize(path) == 0:
        return None
    return path

img_path = capture_interactive_region()
if not img_path:
    print("Cancelled")
    exit(0)

print("Captured:", img_path)

model, processor = load("mlx-community/DeepSeek-OCR-2-8bit", trust_remote_code=False)

prompt = "<|grounding|>Convert the document to markdown."
formatted_prompt = apply_chat_template(processor, model.config, prompt, num_images=1)

result = generate(
    model=model,
    processor=processor,
    image=img_path,
    prompt=formatted_prompt,
    max_tokens=1000,
    cropping=True,
    min_patches=1,
    max_patches=6,
)

import re
raw = result if isinstance(result, str) else result.text
# strip grounding tags: <|ref|>...<|/ref|><|det|>...<|/det|>
text = re.sub(r"<\|ref\|>(.*?)<\|/ref\|><\|det\|>.*?<\|/det\|>", r"\1", raw, flags=re.DOTALL)
text = text.strip()
print("OCR result:\n", text)

subprocess.run("pbcopy", input=text.encode(), check=True)
print("Copied to clipboard.")
