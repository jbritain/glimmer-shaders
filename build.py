import json
import time
import os
from watchdog.events import FileSystemEvent, FileSystemEventHandler
from watchdog.observers import Observer

json_path = "./pack.json"
shaders_path = "shaders"
version = "460 compatibility"

OVERWORLD = ("OVERWORLD", "world0")
NETHER = ("THE_NETHER", "world1")
END = ("THE_END", "world-1")

def create_linked_shader_program(program_path, file_path, program_types=["vsh", "fsh"], dimensions=[OVERWORLD, NETHER, END]):
  for dim in dimensions:
    for program_type in program_types:
      if not os.path.exists(f"{shaders_path}/{dim[1]}/"):
        os.makedirs(f"{shaders_path}/{dim[1]}/")
      with open(f"{shaders_path}/{dim[1]}/{program_path}.{program_type}", "w") as p:
        program_string = []
        program_string.append(f"#version {version}")
        program_string.append(f"#define WORLD_{dim[0]}")
        program_string.append(f"#define {program_type}")
        program_string.append(f"#include {file_path}")

        p.writelines([l + "\n" for l in program_string])

def generate_gbuffers(pack):
  for program, file in pack["programs"]["gbuffers"].items():
    create_linked_shader_program(f"gbuffers_{program}", f"program/gbuffers_{file}.glsl")

def generate_pack():
  with open(json_path) as j:
    pack = json.loads("".join(j.readlines()))

  generate_gbuffers(pack)


class Handler(FileSystemEventHandler):
  def on_any_event(self, event: FileSystemEvent) -> None:
    try:
      print("Rebuilding...")
      generate_pack()

    except Exception:
      return

if __name__ == "__main__":
  generate_pack()
  # observer = Observer()
  # handler = Handler()
  # observer.schedule(handler, json_path)
  # observer.schedule(handler, shaders_path, recursive=True)
  # observer.start()

  # try:
  #   while True:
  #     time.sleep(1)
  # finally:
  #   observer.stop()
  #   observer.join()