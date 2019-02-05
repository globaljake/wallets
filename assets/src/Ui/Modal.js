const MODAL_ANIMATION = "UiModal-fadeOutDown";

export default {
  start: app =>
    Promise.resolve().then(() => {
      customElements.define(
        "wallets-ui-modal",
        class extends HTMLElement {
          constructor() {
            super();
          }

          connectedCallback() {
            // this.addEventListener("animationend", this._onAnimationEnd);
          }
        }
      );
    })
};
