from block_wrangler.block_wrangler import *
from pathlib import Path
from block_wrangler.block_wrangler.distant_horizons import DH_BLOCK_WATER, DH_BLOCK_LEAVES, DH_BLOCK_LAVA


from caseconverter import pascalcase


shaderpack_root = Path(__file__).parent


def main():
    tags = load_tags()

    mapping = BlockMapping.solve({
        'water': Flag(blocks('minecraft:water'), DH_BLOCK_WATER),
        'ice': Flag(blocks('minecraft:ice')),
        'lava': Flag(blocks('minecraft:lava'), DH_BLOCK_LAVA),
        'plant': Flag(tags['plant']),
        'leaves': Flag(tags['minecraft:leaves'], DH_BLOCK_LEAVES),
        'sway': EnumFlag({
            'upper': tags['sway/upper'],
            'lower': tags['sway/lower'],
            'short': tags['sway/short'],
            'hanging': tags['sway/hanging'],
            'floating': tags['sway/floating'],
            'full': tags['sway/full']
        }),
        'tinted_glass': Flag(blocks('minecraft:tinted_glass')),

        'fire_light_color': Flag(blocks('minecraft:fire', 'minecraft:campfire', 'minecraft:jack_o_lantern', 'minecraft:lava')),
        'torch_light_color': Flag(blocks('minecraft:torch', 'minecraft:wall_torch', 'minecraft:lantern')),
        'soul_fire_light_color': Flag(blocks('minecraft:soul_torch', 'minecraft:soul_wall_torch', 'minecraft:soul_fire', 'minecraft:soul_campfire', 'minecraft:soul_lantern')),
        'redstone_light_color': Flag(blocks('minecraft:redstone_wire', 'minecraft:redstone_torch', 'minecraft:redstone_wall_torch')),

        'purple_froglight': Flag(blocks('minecraft:pearlescent_froglight')),
        'yellow_froglight': Flag(blocks('minecraft:ochre_froglight')),
        'green_froglight': Flag(blocks('minecraft:verdant_froglight')),

        'max_emission': Flag(blocks('minecraft:nether_portal', 'minecraft:lava')),

        'lets_light_through': Flag(blocks('minecraft:barrier', 'minecraft:beacon', 'minecraft:azalea', 'minecraft:flowering_azalea', 'minecraft:bamboo', 'minecraft:bell', 'minecraft:sculk_sensor', 'minecraft:calibrated_sculk_sensor', 'minecraft:campfire', 'minecraft:soul_campfire', 'minecraft:cauldron', 'minecraft:chest', 'minecraft:chorus_flower', 'minecraft:chorus_plant', 'minecraft:conduit', 'minecraft:daylight_detector', 'minecraft:decorated_pot', 'minecraft:dirt_path', 'minecraft:dragon_egg', 'minecraft:enchanting_table', 'minecraft:end_portal_frame', 'minecraft:end_rod', 'minecraft:ender_chest', 'minecraft:farmland', 'minecraft:flower_pot', 'minecraft:grindstone', 'minecraft:hopper', 'minecraft:iron_bars', 'minecraft:ladder', 'minecraft:lectern', 'minecraft:lightning_rod', 'minecraft:lily_pad', 'minecraft:moss_carpet', 'minecraft:piston:extended=true', 'minecraft:piston_head', 'minecraft:sticky_piston:extended=true', 'minecraft:snow', 'minecraft:stonecutter', 'minecraft:trapped_chest') + tags['minecraft:anvil'] + tags['minecraft:wool_carpets'] + tags['minecraft:doors'] + tags['minecraft:fence_gates'] + tags['minecraft:fences'] + tags['minecraft:trapdoors'] + tags['minecraft:stairs'] + tags['minecraft:slabs']),

        'end_portal': Flag(blocks('minecraft:end_portal', 'minecraft:end_gateway')),
    },
        MappingConfig(
        start_index=1001,
        pragma="MATERIAL_IDS_GLSL"
    )

    )

    with shaderpack_root.joinpath('../shaders/block.properties').open('w') as f:
        f.write(mapping.render_encoder())
    with shaderpack_root.joinpath('../shaders/lib/common/materialIDs.glsl').open('w') as f:
        f.write(mapping.render_decoder())


if __name__ == '__main__':
    main()
