<template>
  <div>
    <a href="#/game">Play</a> <br>
    <a href="#/profile">Profile</a> <br>
    <a href="#/rules/">How to play</a> <br>
    <a href="#/settings/">Settings</a> <br>
    <a href="#/exit">Exit</a>
  </div>
</template>

<script>
  export default {
      methods: {
        authorize(event) {
          fetch("/api/v1/login", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json"
            },
            body: JSON.stringify({
              email: event.target.email.value,
              password: event.target.password.value
            })
          }).then((request) => request.json()).then((data) => {
            console.log(data);
          });

          event.preventDefault();
        }
      }
    }
</script>
