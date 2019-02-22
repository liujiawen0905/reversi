export MIX_ENV=prod
export PORT=5000
echo "Stopping old copy of app, if any..."

_build/prod/rel/reversi/bin/reversi stop || true

echo "Starting app..."

# Start to run in background from shell.
_build/prod/rel/reversi/bin/reversi start
# Foreground for testing and for systemd
#_build/prod/rel/reversi/bin/reversi foreground
