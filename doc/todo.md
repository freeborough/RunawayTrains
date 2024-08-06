# Runaway Trains: TODO

## Redo Collision Detection

Use ShapeCast3D instead of our janky method!  It's just the proper, simpler way to do it, but should
also fix the bend on a straight bug.

## Track to Corner Immediately

At the moment the track corner is placed after the next straight piece is, retroactively fixing the
previous piece of track.  However, it will be a much better user experience, to change it as soon as
the facing is changed.

## Initialise Track

We need to be able to initialise the track to have more than one piece at the start.  Maybe making a
'place track at' function or similar would both make this easier and share the logic between this
and elsewhere.

## Train

Have a train following the tracks.  Ideally if we can use a Path within each track piece and follow
that, it gives us lots of flexibility in the future for different types of track.

## Level Boundry

Make the level a correct size, then add some area3d's that we can collide with at the edges.

## Pickups

How do we want to do pickups?  Track run directly over like Snake?  Or pass on one side or the other
and pickup with the train?  Have a range or not?

I like the idea of having range such that you'll then run alongside and they'll join the train.  It
also opens up some options regarding stations as needing to be directly on them/adjacent makes them
very easy to block off.  Something we'll have to experiment with, so build the code to allow options
here.

I also like the idea of a powerup that will increase your pickup radius, or something that will
lower your opponent's pickup radius.
