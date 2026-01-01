import json
import time
import os
import shutil
# from watchdog.events import FileSystemEvent, FileSystemEventHandler
# from watchdog.observers import Observer

json_path = "./pack.json"
shaders_path = "shaders"
config_path = "lib/config"
version = "460 compatibility"

OVERWORLD = ("OVERWORLD", "world0")
NETHER = ("THE_NETHER", "world1")
END = ("THE_END", "world-1")


def create_linked_shader_program(program_path, file_path, program_types=["vsh", "fsh"], dimensions=[OVERWORLD, NETHER, END], defines={}):
    for dim in dimensions:
        for program_type in program_types:
            if not os.path.exists(f"{shaders_path}/{dim[1]}/"):
                os.makedirs(f"{shaders_path}/{dim[1]}/")
            with open(f"{shaders_path}/{dim[1]}/{program_path}.{program_type}", "w") as p:
                program_string = []
                program_string.append(f"#version {version}")
                program_string.append(f"#define WORLD_{dim[0]}")
                program_string.append(f"#define {program_type}")
                for macro, value in defines.items():
                    program_string.append(f"#define {macro} {value}")
                program_string.append(f"#include \"/{file_path}\"")



                p.writelines([l + "\n" for l in program_string])


def generate_gbuffers(pack):
    for program, file in pack["programs"]["gbuffers"].items():
        create_linked_shader_program(
            f"gbuffers_{program}", f"program/gbuffer/{file}.glsl")

    if os.path.exists(f"{shaders_path}/program/shadow.glsl"):
        create_linked_shader_program(
            f"shadow", f"program/shadow.glsl")


def generate_post_processing(pack):
    for stage in ["setup", "prepare", "composite", "deferred", "shadowcomp"]:
        if os.path.exists(f"{shaders_path}/program/{stage}"):
            for i, program in enumerate(pack["programs"][stage]):
                create_linked_shader_program(
                    f"{stage}{i if i else ''}", f"program/{stage}/{program['path']}.glsl", program["programs"], defines=(program["defines"] if "defines" in program.keys() else {}))

                if 'blend' in program.keys():
                    pack["properties"].append(
                        f"blend.{stage}{i if i else ''} = {program['blend']}")


    if os.path.exists(f"{shaders_path}/program/final.glsl"):
        create_linked_shader_program(
            f"final", f"program/final.glsl")


def generate_properties(pack):
    with open(f"{shaders_path}/shaders.properties", "r+") as f:
        lines = f.readlines()
        if "# !AUTOGENERATE\n" in lines:
            lines = lines[0:lines.index("# !AUTOGENERATE\n") + 1]

        lines = lines + [l + "\n" for l in pack["properties"]]
        print("\n".join(lines))
        f.seek(0)
        f.write("".join(lines))
        f.truncate()


def generate_pack():
    with open(json_path) as j:
        pack = json.loads("".join(j.readlines()))

    pack["properties"] = []

    for dim in [OVERWORLD, NETHER, END]:
        if os.path.exists(f"{shaders_path}/{dim[1]}"):
            shutil.rmtree(f"{shaders_path}/{dim[1]}")
    generate_gbuffers(pack)
    generate_post_processing(pack)
    generate_properties(pack)


generate_pack()

# class Handler(FileSystemEventHandler):
#   def on_any_event(self, event: FileSystemEvent) -> None:
#     try:
#       print("Rebuilding...")
#       generate_pack()

#     except Exception:
#       return

# if __name__ == "__main__":
#   generate_pack()
#   # observer = Observer()
#   # handler = Handler()
#   # observer.schedule(handler, json_path)
#   # observer.schedule(handler, shaders_path, recursive=True)
#   # observer.start()

#   # try:
#   #   while True:
#   #     time.sleep(1)
#   # finally:
#   #   observer.stop()
#   #   observer.join()
