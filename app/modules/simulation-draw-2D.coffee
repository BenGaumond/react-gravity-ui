#Dependencies
geometry = require "./geometry2D"
is_type = require "is-explicit"

Vector = geometry.Vector

CAMERA_SPEED = 5
CAMERA_MIN_SCALE = 0.1
CAMERA_MAX_SCALE = 1000

class CameraCoords
  constructor: ->
    @pos = Vector.zero
    @scale = 1

class Camera
  constructor: ->
    @current = new CameraCoords
    @target = new CameraCoords

  worldToCanvas: (point) ->
    screen_mid = new Vector canvas.width * 0.5, canvas.height * 0.5
    relative = point.sub @current.pos
    relative_scaled = relative.div @current.scale
    relative_scaled.add screen_mid

  canvasToWorld: (point) ->
    screen_mid = new Vector canvas.width * 0.5, canvas.height * 0.5
    adjusted = point.sub screen_mid
    scaled = adjusted.mult @current.scale
    scaled.add @current.pos

  update: (delta_t) ->
    @target.scale = CAMERA_MIN_SCALE if @target.scale < CAMERA_MIN_SCALE
    @target.scale = CAMERA_MAX_SCALE if @target.scale > CAMERA_MAX_SCALE
    @current.pos.ilerp @target.pos, delta_t * CAMERA_SPEED
    @current.scale = geometry.lerp @current.scale, @target.scale, delta_t * CAMERA_SPEED

#Interface
class SimulationDraw2D

  constructor: (@simulation, @canvas) ->
    @context = @canvas.getContext '2d'
    @camera = new Camera

    #Set Camera to Front and Center Canvas
    @camera.target.scale = 1;
    @camera.target.pos.x = canvas.width * 0.5;
    @camera.target.pos.y = canvas.height * 0.5;

    @simulation.on 'interval-start', => clear_canvas.call this
    @simulation.on 'interval-start', => draw_grid.call this
    @simulation.on 'body-update', (body) => draw_body.call this, body
    @simulation.on 'interval-complete', (delta_t)=> @camera.update delta_t

    set_color body for body in @simulation.bodies
    @simulation.on 'body-create', set_color
    @simulation.on 'body-collision-survived', set_color

    #Data
    @options =
      grid: true
      parents: true
      orbits: true
      names: true
      nameRadiusThreshold: 10

    @styles =
      grid:
        stroke: "rgba(255,255,255,0.5)"
        lineWidth: 0.1
      body:
        nameFont: "12px Arial"
        nameColor: "white"


  #PRIVATE DANGLING DRAW METHODS
  clear_canvas = -> 
    @context.clearRect 0, 0, canvas.width, canvas.height

  draw_grid = ->
    return if @options.grid is off

    @context.lineWidth = @styles.grid.lineWidth
    @context.strokeStyle = @styles.grid.stroke

    x_line_delta = @canvas.width / @camera.current.scale
    x = 0

    xOff = (-@camera.current.pos.x / @camera.current.scale + @canvas.width * 0.5) % x_line_delta
    while x < @canvas.width
      @context.beginPath()
      @context.moveTo x + xOff, 0
      @context.lineTo x + xOff, @canvas.height
      @context.stroke()
      x += x_line_delta

    y_line_delta = @canvas.height / @camera.current.scale

    y = 0
    yOff = (-@camera.current.pos.y / @camera.current.scale + @canvas.height * 0.5) % y_line_delta
    while y < @canvas.height
      @context.beginPath()
      @context.moveTo 0, y + yOff
      @context.lineTo @canvas.width, y + yOff
      @context.stroke()
      y += y_line_delta

  draw_body = (body) ->
    radius = body.radius / @camera.current.scale
    pos = @camera.worldToCanvas body.pos

    body.visible = not(pos.x < -radius or pos.x > canvas.width + radius or pos.y < -radius or pos.y > canvas.height + radius)
    return if not body.visible;

    color = body.color

    draw_parent.call this, body if @options.parents
    draw_orbit.call this, body if @options.orbits
    draw_name.call this, body.name, pos, radius if @options.names and radius >= @options.nameRadiusThreshold and body.name?
    draw_selection.call this, pos, radius if body.selected
    #fill circle
    if radius > 2
      startRadius = radius - 1
      grad = @context.createRadialGradient pos.x, pos.y, startRadius, pos.x, pos.y, radius
      grad.addColorStop 0, "rgba(#{color[0]}, #{color[1]}, #{color[2]}, 1.0)"
      grad.addColorStop 1, "rgba(#{color[0]}, #{color[1]}, #{color[2]}, 0)"
      @context.fillStyle = grad

    else
      opacity = geometry.lerp 0.5, 1, radius / 0.5
      opacity = 1 if opacity > 1

      radius = 0.5 if radius < 0.5
      @context.fillStyle = "rgba(#{color[0]}, #{color[1]}, #{color[2]}, #{opacity})"

    @context.beginPath()
    @context.arc pos.x, pos.y, radius, 0, 2 * Math.PI
    @context.closePath()

    @context.fill()

  draw_parent = ->

  draw_orbit = ->

  draw_name = (name, pos, radius) ->
    @context.font = @styles.body.nameFont
    @context.textAlign = "center"
    @context.fillStyle = @styles.body.nameColor
    @context.fillText name, pos.x, pos.y - radius * 1.25

  draw_selection = (pos, radius)->
    radius = 4 if radius < 4
    d = radius * 2

    @context.beginPath()
    @context.strokeStyle = "white";
    @context.lineWidth = 1;
    @context.moveTo pos.x - d, pos.y - d
    @context.lineTo pos.x + d, pos.y - d
    @context.lineTo pos.x + d, pos.y + d
    @context.lineTo pos.x - d, pos.y + d
    @context.lineTo pos.x - d, pos.y - d
    @context.stroke()

  #PRIVATE NON DANGLING  DRAW METHODS
  set_color = (body) ->
    body.color = [255,
    Math.round(256 / (1 + Math.pow(body.mass / 200000, 1))),
    Math.round(256 / (1 + Math.pow(body.mass / 20000, 1)))]

module.exports = SimulationDraw2D