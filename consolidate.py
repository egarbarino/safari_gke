files = [
        "notes.md",
        "getting_started/notes.md",
        "getting_started/initialization/notes.md",
        "getting_started/initialization/init.sh",
        "getting_started/cluster/notes.md",
        "getting_started/cluster/watch_cluster.sh",
        "getting_started/cluster/watch_compute.sh",
        "getting_started/cluster/watch_disks.sh",
        "getting_started/cluster/create_cluster.sh",
        "getting_started/cluster/delete_cluster.sh"
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
    
