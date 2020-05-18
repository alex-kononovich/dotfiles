module.exports = {
  defaultBrowser: "Safari",
  handlers: [
    {
      match: finicky.matchHostnames([
        "localhost",
        "127.0.0.1",
        /(docs|sheets)\.google\.com/,
        /.*newrelic.com/,
        /.*datadoghq.com/,
        /.*miro.com/,
        /.*funretro.io/,
        /.*latticehq.com/
      ]),
      browser: "Google Chrome"
    },
    {
      match: /unbounce/,
      browser: "Google Chrome"
    },
    {
      match: ({ keys }) => keys.option,
      browser: "Google Chrome"
    }
  ]
};
