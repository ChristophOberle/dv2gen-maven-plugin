# get profile from project

import yaml
import sys

with open(sys.argv[1], mode="rt", encoding="utf-8") as file:
    dbt_project = yaml.safe_load(file)

profile = dbt_project['profile']

sys.stdout.write(profile)
sys.stdout.flush()
sys.exit(0)
