<!doctype html>
<html lang="{{ app()->getLocale() }}">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chip &amp; Flip</title>
    <link rel="stylesheet" href="/css/app.css">
    <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">
  </head>
  <body>
    <div id="application">
      <router-view></router-view>
    </div>
    <script>window.pusherKey = "{{config('broadcasting.connections.pusher.key')}}"</script>
    <script src="/js/app.js" charset="utf-8"></script>
  </body>
</html>
