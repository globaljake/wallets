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

      case "Create":
        const { walletId, description, amount } = payload;
        if (!walletId || !description || !amount) return;

        const id = Date.now() + "_transaction";
        const newTransaction = { id, walletId, description, amount };

        save({ [id]: newTransaction, ...transactions });
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