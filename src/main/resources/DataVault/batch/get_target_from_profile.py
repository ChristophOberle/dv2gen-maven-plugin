# get target from profile

import yaml
import sys

with open(sys.argv[1], mode="rt", encoding="utf-8") as file:
    profiles = yaml.safe_load(file)

target = profiles[sys.argv[2]]['target']

sys.stdout.write(target)
sys.stdout.flush()
sys.exit(0)
