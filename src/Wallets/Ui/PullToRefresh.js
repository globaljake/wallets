export default {
  start(_app) {
    customElements.define(
      "wallets-ui-pull-to-refresh",
      class extends HTMLElement {
        constructor() {
          super();
        }

        connectedCallback() {
          let options = {
            root: null, // relative to document viewport
            rootMargin: "0px", // margin around root. Values are similar to css property. Unitless values not allowed
            threshold: 1.0 // visible amount of item shown in relation to root
          };

          let observer = new IntersectionObserver(() => {
            alert("HEY");
            console.log("hey");
          }, options);
          // this.dispatchEvent(new CustomEvent("refresh"));
        }
      }
    );
  }
};
