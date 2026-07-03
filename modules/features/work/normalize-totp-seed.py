from pathlib import Path
from urllib.parse import parse_qs, urlparse
import sys


value = Path(sys.argv[1]).read_text().strip()

if value.startswith("otpauth://"):
    value = parse_qs(urlparse(value).query).get("secret", [""])[0]

if value.startswith("base32:"):
    value = value[len("base32:") :]

print(value, end="")
