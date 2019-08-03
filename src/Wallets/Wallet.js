const generateUUID = () => {
  // Public Domain/MIT
  var d = new Date().getTime();
  if (
    typeof performance !== "undefined" &&
    typeof performance.now === "function"
  ) {
    d += performance.now(); //use high-precision timer if available
  }
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) {
    var r = (d + Math.random() * 16) % 16 | 0;
    d = Math.floor(d / 16);
    return (c === "x" ? r : (r & 0x3) | 0x8).toString(16);
  });
};

const init = app => {
  const saveAndSendAll = wallets => {
    localStorage.setItem("wallets", JSON.stringify(wallets));
    app.ports.walletInbound.send({
      tag: "IndexResponse",
      wallets: Object.keys(wallets).map(key => wallets[key])
    });
  };
  app.ports.walletOutbound.subscribe(({ tag, ...payload }) => {
    const wallets = JSON.parse(localStorage.getItem("wallets")) || {};
    switch (tag) {
      case "Create":
        const id = generateUUID();
        const { title, emoji, budget, available } = payload;
        const newWallet = { id, title, emoji, budget, available };

        saveAndSendAll({ [id]: newWallet, ...wallets });
        return;

      case "Index":
        const walletsList = Object.keys(wallets).map(key => wallets[key]);

        app.ports.walletInbound.send({
          tag: "IndexResponse",
          wallets: walletsList
        });
        return;

      case "Show":
        // const walletsList = Object.keys(wallets).map(key => wallets[key]);

        // app.ports.walletInbound.send({ tag, wallet: wallets[payload.id] });
        return;

      case "Delete":
        const walletsListDelete = Object.keys(wallets).map(key => wallets[key]);
        saveAndSendAll(walletsListDelete.filter(({ id }) => id !== payload.id));

        return;

      default:
        return;
    }
  });
};

export default { init };
