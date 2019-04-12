import CustomElements from "./CustomElements";

const ANIMATION_END = !!window.webkitURL ? "webkitAnimationEnd" : "animationend";

const opositeTransition = t => {
  if (t === "right") {
    return "left";
  } else if (t === "left") {
    return "right";
  }
};

export default {
  start: app => {
    CustomElements.define(
      "wallets-ui-transition",
      HTMLElement =>
        class extends HTMLElement {
          constructor() {
            super();
          }
          connectedCallback() {
            app.ports.uiTransitionSetup.subscribe(({ url, direction }) => {
              const appNode = this.firstChild;

              const pageCloneNode = appNode.cloneNode(true);
              app.ports.uiTransitionIsSet.send(url);
              if (!direction) return;
              pageCloneNode.id = "clone";
              pageCloneNode.classList.add("absolute", "pin");
              this.appendChild(pageCloneNode);

              this._direction = (direction || "").toLowerCase();
              appNode.classList.add(`offscreen-${opositeTransition(this._direction)}`);
            });

            app.ports.uiTransitionStart.subscribe(() => {
              const pageCloneNode = document.getElementById("clone");
              if (!pageCloneNode) return;
              const appNode = this.firstChild;

              appNode.classList.remove(`offscreen-${opositeTransition(this._direction)}`);
              appNode.classList.add("animate", `slide-in-${this._direction}`);
              pageCloneNode.classList.add("animate", `slide-out-${this._direction}`);
              pageCloneNode.addEventListener(ANIMATION_END, () => {
                this.removeChild(pageCloneNode);
                appNode.classList.remove("animate", `slide-in-${this._direction}`);
                appNode.chosenTransition = undefined;
              });
            });
          }
        }
    );
  }
};
