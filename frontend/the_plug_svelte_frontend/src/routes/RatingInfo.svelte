<script lang="ts">

</script>

<main class="p-6 bg-darkAsparagus text-olivine min-h-screen flex flex-col space-y-6">
    <div class="flex flex-col md:flex-row gap-6">
        <section class="bg-darkMossGreen p-6 rounded-lg shadow-lg flex-1">
            <h1 class="text-2xl font-bold mb-4">Beta Reputation System</h1>
            <p class="font-bold mb-1">
                The Beta Reputation System leverages an advanced statistical model to dynamically evaluate users based on their interactions and feedback within a platform.
            </p>
            <p class="font-bold mb-1">
                It uses the Beta distribution, which is ideal for modeling uncertainty in proportions, such as "good vs. bad" ratings.
            </p>
            <p class="font-bold mb-1">
                It is based on reports of users rated as satisfying or unsatisfying cooperation which are used to calculate probability of high satisfaction for next users.
                This probability is computed as mean of Beta distribution based on rated user satisfaction reports.
            </p>
            <p class="font-bold mb-1">
                This approach also assures that users with more reports are more trustworthy to cooperate.
            </p>
            <p class="font-bold">
                To eliminate dishonest users system detects partners (users who try to overstate someone's rating) and slanders (users who try to underestimate someone's rating).
                This actions is based on quantiles of Beta distribution which reject this extreme cases.
            </p>
        </section>
    </div>
</main>
