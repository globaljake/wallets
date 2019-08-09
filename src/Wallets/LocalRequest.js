import Wallet from "./Wallet";
import Transaction from "./Transaction";

const init = () => {
  const RESOURCES = {
    wallet: Wallet,
    transaction: Transaction
  };

  const open = XMLHttpRequest.prototype.open;
  const send = XMLHttpRequest.prototype.send;

  XMLHttpRequest.prototype.open = function(_, url) {
    this._url = url;
    if (!this._url.includes("localrequest")) return open.apply(this, arguments);
    arguments[1] = "/localrequest";
    return open.apply(this, arguments);
  };

  XMLHttpRequest.prototype.send = function(payloadString) {
    if (!this._url.includes("localrequest")) return send.apply(this, arguments);

    const payload = JSON.parse(payloadString);
    const resource = this._url.split("/")[1];
    const action = this._url.split("/")[2];
    const db = RESOURCES[resource] || {};
    const dbAction = db[action] || (() => Promise.reject("Resource not found"));

    dbAction(payload)
      .then(data => {
        Object.defineProperty(this, "response", { writable: true });
        this.response = JSON.stringify({ data });
        send.apply(this, arguments);
      })
      .catch(err => {
        console.log("LocalRequest Error:", err);
        send.apply(this, arguments);
      });
  };
};

export default { init };
