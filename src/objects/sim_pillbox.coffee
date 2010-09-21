# The pillbox is a map object, and thus a slightly special case of world object.

{max}       = Math
WorldObject = require '../world_object'


class SimPillbox extends WorldObject
  charId: 'p'

  # This is a MapObject; it is constructed differently.
  constructor: (map, @x, @y, @owner_idx, @armour, @speed) ->
    if arguments.length == 1
      super
    else
      super(null)

    # The Simulation is passed to us by `spawnMapObjects`.
    @on 'postCreate', (@sim) =>

    # After initialization on client and server set-up the cell reference.
    @on 'postInitialize', =>
      @updateCell()

    # Keep our non-synchronized attributes up-to-date on the client.
    @on 'postNetUpdate', =>
      @updateCell()
      # FIXME: retile when owner changes.
      @owner_idx = if @owner then @owner.tank_idx else 255

  # Helper that updates the cell reference, and ensures a back-reference as well.
  updateCell: ->
    newCell = @sim.map.cellAtTile(@x, @y)
    return if @cell == newCell

    delete @cell.pill if @cell
    @cell = newCell
    @cell.pill = this
    @cell.retile()

  # The state information to synchronize.
  serialization: (isCreate, p) ->
    @x = p('B', @x)
    @y = p('B', @y)

    @owner = p('T', @owner)
    @armour = p('B', @armour)
    @speed = p('B', @speed)

  update: ->
    return if @armour == 0
    # FIXME: swat at the annoying flies

  takeShellHit: (shell) ->
    @armour = max(0, @armour - 1)
    @cell.retile()
    # FIXME: do something with speed

SimPillbox.register()


#### Exports
module.exports = SimPillbox
