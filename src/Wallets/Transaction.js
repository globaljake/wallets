const init = app => {
  const save = transactions => {
    localStorage.setItem("transactions", JSON.stringify(transactions));
  };
  app.ports.transactionOutbound.subscribe(({ tag, ...payload }) => {
    const transactions = JSON.parse(localStorage.getItem("transactions")) || {};
    switch (tag) {
      case "Index":
        app.ports.transactionInbound.send({
          tag: "IndexResponse",
          idList: Object.keys(transactions).sort(),
          transactions: transactions
        });
        return;

      case "IndexByWalletId":
        if (!payload.walletId) return;
        const transByWalletId = Object.keys(transactions).reduce((acc, key) => {
          const current = transactions[key];
          if (current.walletId === payload.walletId) {
            acc[current.id] = { ...current };
          }
          return acc;
        }, {});

        app.ports.transactionInbound.send({
          tag: "IndexResponse",
          idList: Object.keys(transByWalletId).sort(),
          transactions: transByWalletId
        });
        return;

      case "Create":
        const { walletId, description, amount } = payload;
        const wallets = JSON.parse(localStorage.getItem("wallets")) || {};
        if (!walletId || !description || !amount) return;
        if (!wallets[walletId]) return;

        const id = Date.now() + "_transaction";
        const newTransaction = { id, walletId, description, amount };
        save({ [id]: newTransaction, ...transactions });

        wallets[walletId].available = wallets[walletId].available - amount;
        localStorage.setItem("wallets", JSON.stringify(wallets));

        app.ports.transactionInbound.send({
          tag: "ShowResponse",
          transaction: newTransaction
        });
        return;

      default:
        return;
    }
  });
};

export default { init };
