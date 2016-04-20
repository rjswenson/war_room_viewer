# war_room_viewer

A basic card catalog.  The goal for this sucker is to assist in a closed source game project I'm working on.  While the game might be closed source, this card catalog will be universal and basic.

====

#### What?
- create CSV `pipe separated` data files for your favorite systems
- modeled after the rank/paragon unit system made popular by **Warcraft III** and **Starcraft:BW**
- add animated portrait and unit `pngs`, `jpegs`, and [gifs](http://vignette2.wikia.nocookie.net/starcraft/images/e/ed/Marine_SC2_GameAnim1.gif/revision/latest?cb=20080605172207).
- run as many analytics and diagnostics as you prefer on their databanks.  Min-Max~!

#### How?
1.  get ruby, github, etc working
2.  clone or fork the repo
3.  add your own images and data (or dont for now)
4.  run `rake schlepp:process[units]`
5.  pop into the console and create an admin user
6.  run `rails s`, in web browser go to localhost:3000/admin
7.  enjoy your new data
====
#### Things to do:
- [X] basic system of: mongodb, schlepp, active_admin
- [ ] wrap it one of the new fangled [Electron](http://electron.atom.io/)
- [ ] basic auth
- [ ] dynamic HTML5 design that fits all logical form factors
