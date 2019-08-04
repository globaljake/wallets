const init = app => {
  const saveAndSendAll = wallets => {
    localStorage.setItem("wallets", JSON.stringify(wallets));
    app.ports.walletInbound.send({
      tag: "IndexResponse",
      wallets: Object.keys(wallets)
        .sort()
        .map(key => wallets[key])
    });
  };
  app.ports.walletOutbound.subscribe(({ tag, ...payload }) => {
    const wallets = JSON.parse(localStorage.getItem("wallets")) || {};
    switch (tag) {
      case "Create":
        const id = Date.now() + "";
        const { title, emoji, budget, available } = payload;
        const newWallet = { id, title, emoji, budget, available };

        saveAndSendAll({ [id]: newWallet, ...wallets });
        return;

      case "Index":
        const walletsList = Object.keys(wallets)
          .sort()
          .map(key => wallets[key]);

        app.ports.walletInbound.send({
          tag: "IndexResponse",
          wallets: walletsList
        });
        return;

      case "Show":
        // const walletsList = Object.keys(wallets).map(key => wallets[key]);

        // app.ports.walletInbound.send({ tag, wallet: wallets[payload.id] });
        location.reload(true);
        return;

      case "Update":
        if (payload.amount && wallets[payload.id]) {
          wallets[payload.id].available =
            wallets[payload.id].available - payload.amount;
          saveAndSendAll(wallets);
        }

        return;
      case "Delete":
        delete wallets[payload.id];
        saveAndSendAll(wallets);

        return;

      default:
        return;
    }
  });
};

export default { init };
