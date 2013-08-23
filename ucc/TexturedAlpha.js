define([
  'pex/materials/Material',
  'pex/gl/Context',
  'pex/gl/Program',
  'pex/geom/Vec4',
  'pex/utils/ObjectUtils',
  'lib/text!ucc/TexturedAlpha.glsl'
  ], function(Material, Context, Program, Vec4, ObjectUtils, TexturedAlphaGLSL) {

  function TexturedAlpha(uniforms) {
    this.gl = Context.currentContext.gl;
    var program = new Program(TexturedAlphaGLSL);

    var defaults = {
      alpha: 1
    };

    var uniforms = ObjectUtils.mergeObjects(defaults, uniforms);

    Material.call(this, program, uniforms);
  }

  TexturedAlpha.prototype = Object.create(Material.prototype);

  return TexturedAlpha;
});