# Vocabulary

Vocabulary is a vocabulary trainer for SailfishOS designed to be used independent of the language you want to learn.

# Adaptive training mode

The adaptive training mode is designed in a way that prefers new / unknown vocabulary over known vocabulary.

Each vocabulary gets a *priority* between 1 and 100 which starts at 100.
Every time a vocabulary is remembered correctly the priority gets reduced (default: by 3), for every mistake the priority is increased (default: by 10).
For every priority point the vocabulary gets an additional chance of getting drawn from the vocabulary pool.

# Current features

 * Add vocabularies to your vocabulary list
 * Edit added vocabulary
 * View details of vocabulary
 * List all known vocabularies
 * Search for vocabulary
 * Adaptive training mode
 * Adjust training mode

# Planned features

 * Import / export of vocabulary list
 * Detailed statistics about all vocabulary
 * Customisation settings

# License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

```
http://www.apache.org/licenses/LICENSE-2.0
```

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
