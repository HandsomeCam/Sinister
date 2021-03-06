const SINK_TARGET = "http://localhost:9000/sink";

const sleep = (ms) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

var callback = async (/* details */) => {
  await sleep(200);
};

const addArtificialLag = () => {
  // eslint-disable-next-line no-undef
  withActiveSites((activeSites) => {
    const lagTargets = activeSites.map((site) => `https://${site}/*`);

    var filter = {
      urls: lagTargets,
    };
    const extraInfoSpec = ["blocking"];
    var webRequest = chrome.webRequest;
    webRequest.handlerBehaviorChanged();
    webRequest.onBeforeRequest.addListener(callback, filter, extraInfoSpec);
  });
};

const handleInterceptedMessage = (message) => {
  const messageWithTimestamp = { ...message };

  messageWithTimestamp.ts = Date.now();

  try {
    fetch(SINK_TARGET, {
      method: "POST",
      mode: "no-cors",
      body: JSON.stringify(messageWithTimestamp),
    });
  } catch {
    // ignored
  }
};

const onMessageListener = (request /*, sender */) => {
  // console.log(
  //   sender.tab
  //     ? "from a content script:" + sender.tab.url
  //     : "from the extension"
  // );
  if (request.type === "interceptedMessage") {
    handleInterceptedMessage(request.clientMessage);
  }
};

chrome.runtime.onMessage.addListener(onMessageListener);

addArtificialLag();
