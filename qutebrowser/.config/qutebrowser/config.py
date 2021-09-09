config.load_autoconfig()

config.set('colors.webpage.darkmode.enabled', True)
c.editor.command = ["xst", "-e", "nvim", "{}"]
config.source('gruvbox.py')
