# get target from profile

import yaml
import sys

with open(sys.argv[1], mode="rt", encoding="utf-8") as file:
    profiles = yaml.safe_load(file)

user = profiles[sys.argv[2]]['outputs'][sys.argv[3]]['user']

sys.stdout.write(user)
sys.stdout.flush()
sys.exit(0)
