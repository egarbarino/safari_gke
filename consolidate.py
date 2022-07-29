#!/usr/bin/python
files = [
        "notes.md",
        "getting_started/notes.md",
        "getting_started/initialization/notes.md",
        "getting_started/cluster/notes.md",
        "getting_started/launching_pods/notes.md",
        ]

with open("README.md",'w') as consolidated:
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
                consolidated.write(line)
            if file.endswith(".sh"):
                consolidated.write("```\n\n")
    
