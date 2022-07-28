files = [
        "1-getting_started/0-first/README.md",
        "1-getting_started/1-init/init.sh",
        "1-getting_started/2-cluster/create_cluster.sh"
        ]

with open("README.md",'w') as consolidated:
    for file in files:
        print(file)
        with open(file, 'r') as handle:
            if file.endswith(".sh"):
                parts = file[0:-3].split("/")
                title = parts[len(parts)-1].replace("_"," ").replace("-"," ").title()
                consolidated.write("### {}\n\n".format(title))
                consolidated.write("Source: [{}]({})\n\n".format(file,file))
                consolidated.write("``` bash\n")
            for i,line in enumerate(handle.readlines()):
                consolidated.write(line)
            if file.endswith(".sh"):
                consolidated.write("```\n\n")
    
