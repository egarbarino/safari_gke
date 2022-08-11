#!/usr/bin/python
files = [
        "getting_started/notes.md",
        "getting_started/initialization/notes.md",
        "getting_started/cluster/notes.md",
        "getting_started/launching_pods/notes.md",
        "getting_started/life_cycle/notes.md",
        "getting_started/self-healing/notes.md",
        ]
""" 
        "notes.md",
        "ha_and_hs/notes.md",
        "ha_and_hs/launching_deployments/notes.md",
        "ha_and_hs/strategies/notes.md",
        "ha_and_hs/roll_back/notes.md",
        "ha_and_hs/scaling/notes.md",
        "ha_and_hs/service_discovery_use_cases/notes.md",
        "ha_and_hs/service_public_internet/notes.md",       
        "ha_and_hs/canary/notes.md",               
"""
with open("xxxxREADME.md",'w') as consolidated:
    for file in files:
        print(file)
        with open(file, 'r') as handle:

            if file.endswith(".sh"):
                parts = file[0:-3].split("/")
                title = parts[len(parts)-1].replace("_"," ").replace("-"," ").title()
                consolidated.write("#### {}\n\n".format(title))
                consolidated.write("Source: [{}]({})\n\n".format(file,file))
                consolidated.write("``` bash\n")
            for i,line in enumerate(handle.readlines()):
                if file.endswith(".md") and i == 1:
                    dir = "/".join(file.split("/")[0:-1])
                    consolidated.write("Source: [{}]({})\n".format(dir,dir))
                consolidated.write(line)
            if file.endswith(".sh"):
                consolidated.write("```\n\n")
    
