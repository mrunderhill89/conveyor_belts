# conveyor_belts
By Kevin "mrunderhill89" Cameron

This mod adds conveyor belts to Minetest that are controlled through mesecons. Unlike previous mods that added conveyor belts, these belts can move players and other objects in addition to blocks (the code is the same as that used for pistons and movestones), so they can be used to create moving sidewalks among other things.

Conveyor belts follow the [right-hand rule](https://en.wikipedia.org/wiki/Right-hand_rule) and can be rotated using a screwdriver if you need them on their side. There are markings on the side of the conveyor that will tell you which way a block will move when the belt is activated. Belts can be reversed by activating them from the opposite side.

Because of the way mesecons signals travel through a wire, you can arrange conveyor belts so that a block or player is moved from one end of a chain of conveyor to the other almost instantly. This "streamlining" is possible because each element of the conveyor belt is activated individually, so an object gets moved from one part of the belt to the other right when the second belt is activated in the same frame.

Requirements
--
This mod requires that you have the mesecons main mod installed. The Technic mod offers another way to create many conveyor belts at once, but is optional.
