const init = app => {
  const save = wallets => {
    localStorage.setItem("wallets", JSON.stringify(wallets));
  };
  app.ports.walletOutbound.subscribe(({ tag, ...payload }) => {
    const wallets = JSON.parse(localStorage.getItem("wallets")) || {};
    switch (tag) {
      case "Index":
        app.ports.walletInbound.send({
          tag: "IndexResponse",
          idList: Object.keys(wallets).sort(),
          wallets: wallets
        });
        return;

      case "Show":
        if (!payload.id) return;

        app.ports.walletInbound.send({
          tag: "ShowResponse",
          wallet: wallets[payload.id]
        });
        return;

      case "Create":
        const { title, emoji, budget, available } = payload;
        if (!title || !emoji || !budget || !available) return;

        const id = Date.now() + "";
        const newWallet = { id, title, emoji, budget, available };

        save({ [id]: newWallet, ...wallets });
        app.ports.walletInbound.send({
          tag: "ShowResponse",
          wallet: newWallet
        });
        return;

      case "Update":
        if (!payload.id || !payload.amount) return;
        if (!wallets[payload.id]) return;

        wallets[payload.id].available =
          wallets[payload.id].available - payload.amount;

        save(wallets);
        app.ports.walletInbound.send({
          tag: "ShowResponse",
          wallet: wallets[payload.id]
        });
        return;

      case "Delete":
        if (!payload.id) return;
        if (!wallets[payload.id]) return;

        delete wallets[payload.id];
        save(wallets);
        app.ports.walletInbound.send({
          tag: "DeleteResponse",
          id: payload.id
        });
        return;

      case "ReloadTest":
        location.reload(true);
        return;

      default:
        return;
    }
  });
};

export default { init };
