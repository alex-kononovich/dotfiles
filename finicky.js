module.exports = {
  defaultBrowser: "Safari",
  options: {
    hideIcon: true
  },
  handlers: [
    {
      match: finicky.matchHostnames([
        "localhost",
        "127.0.0.1",
        /(docs|sheets|drive)\.google\.com/,
        /forms\.gle/,
        /bamboohr\.com/,
        /expensify\.com/,
        /.*figma\.com/,
        /.*newrelic\.com/,
        /.*datadoghq\.com/,
        /.*miro\.com/,
        /.*easyretro\.io/,
        /.*remo\.co/,
        /.*latticehq\.com/
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
