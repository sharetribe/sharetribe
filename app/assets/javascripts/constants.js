class Constant {
  constructor(options={}) {
    this.OVERLAY_Z_INDEX = options.overlayZIndex || 20;
    this.CLONE_Z_INDEX = this.OVERLAY_Z_INDEX + 1;
    this.TOOLTIP_Z_INDEX = this.CLONE_Z_INDEX + 1;
  }

  reload(options={}) {
    this.OVERLAY_Z_INDEX = options.overlayZIndex || 20;
    this.CLONE_Z_INDEX = this.OVERLAY_Z_INDEX + 1;
    this.TOOLTIP_Z_INDEX = this.CLONE_Z_INDEX + 1;
  }
}

export default new Constant();
