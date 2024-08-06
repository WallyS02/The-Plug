<script lang="ts">
  import Router from "svelte-spa-router";
  import Home from "./routes/Home.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import AddDrug from "./routes/AddDrug.svelte";
  import AddLocation from "./routes/AddLocation.svelte";
  import AccountPanel from "./routes/AccountPanel.svelte";
  import Register from "./routes/Register.svelte";
  import Login from "./routes/Login.svelte";
  import RequestMeeting from "./routes/RequestMeeting.svelte";
  import PlugPanel from "./routes/PlugPanel.svelte";
  import AddRating from "./routes/AddRating.svelte";
  import Navbar from "./lib/Navbar.svelte";
  import Footer from "./lib/Footer.svelte";
  import MeetingPanel from "./routes/MeetingPanel.svelte";

  const routes = {
    '/': Home,
    '/register': Register,
    '/login': Login,
    '/add-drug': AddDrug,
    '/add-location': AddLocation,
    '/account/:id': AccountPanel,
    '/plug/:id': PlugPanel,
    '/meeting/:id': MeetingPanel,
    '/add-rating/:meeting-id': AddRating,
    '/request-meeting/:plug-id': RequestMeeting,
    '*': NotFound,
  }
</script>

<style>
  @import 'tailwindcss/tailwind.css';
</style>

<main class="p-4">
  <Navbar/>
  <Router {routes} />
  <Footer/>
</main>
