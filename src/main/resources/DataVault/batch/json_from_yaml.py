# get profile from project

import sys
import yaml
import json

with open(sys.argv[1], mode="rt", encoding="utf-8") as file:
    content = json.dumps(yaml.safe_load(file))
sys.stdout.write(content)
sys.stdout.flush()
sys.exit(0)
