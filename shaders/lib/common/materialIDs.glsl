#if !defined(MATERIAL_IDS_GLSL)
#define MATERIAL_IDS_GLSL
// This file was automatically generated by block_wrangler

#define MATERIAL_WATER 1026
bool materialIsWater(int id) {
  return id == 1026;
}

#define MATERIAL_ICE 1025
bool materialIsIce(int id) {
  return id == 1025;
}

#define MATERIAL_LAVA 1008
bool materialIsLava(int id) {
  return id == 1008;
}

bool materialIsPlant(int id) {
  return id == 1004 ||
  id == 1005 ||
  id == 1006 ||
  id == 1017 ||
  id == 1019 ||
  id == 1021 ||
  id == 1022 ||
  id == 1023 ||
  id == 1024;
}

#define MATERIAL_LEAVES 1019
bool materialIsLeaves(int id) {
  return id == 1019;
}

struct Sway {
  int value;
};
const Sway Sway_NONE = Sway(0);
const Sway Sway_UPPER = Sway(1);
const Sway Sway_LOWER = Sway(2);
const Sway Sway_HANGING = Sway(3);
const Sway Sway_FLOATING = Sway(4);
const Sway Sway_FULL = Sway(5);
Sway materialSwayType(int id) {
  if (id == 1023) return Sway_UPPER;
  if (id == 1005 || id == 1022) return Sway_LOWER;
  if (id == 1015 || id == 1020 || id == 1021) return Sway_HANGING;
  if (id == 1004) return Sway_FLOATING;
  if (id == 1019) return Sway_FULL;
  return Sway_NONE;
}

#define MATERIAL_TINTED_GLASS 1018
bool materialIsTintedGlass(int id) {
  return id == 1018;
}

bool materialIsFireLightColor(int id) {
  return id == 1003 || id == 1008 || id == 1016 || id == 1017;
}

bool materialIsTorchLightColor(int id) {
  return id == 1014 || id == 1015;
}

bool materialIsSoulFireLightColor(int id) {
  return id == 1002 || id == 1013;
}

#define MATERIAL_REDSTONE_LIGHT_COLOR 1012
bool materialIsRedstoneLightColor(int id) {
  return id == 1012;
}

#define MATERIAL_PURPLE_FROGLIGHT 1011
bool materialIsPurpleFroglight(int id) {
  return id == 1011;
}

#define MATERIAL_YELLOW_FROGLIGHT 1010
bool materialIsYellowFroglight(int id) {
  return id == 1010;
}

#define MATERIAL_GREEN_FROGLIGHT 1009
bool materialIsGreenFroglight(int id) {
  return id == 1009;
}

bool materialIsMaxEmission(int id) {
  return id == 1007 || id == 1008;
}

bool materialIsLetsLightThrough(int id) {
  return id == 1001 ||
  id == 1002 ||
  id == 1003 ||
  id == 1004 ||
  id == 1005 ||
  id == 1006;
}

#endif // MATERIAL_IDS_GLSL
