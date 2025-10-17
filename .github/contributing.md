# contributing guidelines
thank you for your interest in contributing to **ecommerce-etl-dq** 💙  
this project follows clean and modular development practices to ensure transparency and reproducibility.

## how to contribute
1. fork the repository  
2. create a new branch for your feature or fix:  
   `git checkout -b feature/my-new-function`
3. commit your changes with clear messages:  
   `git commit -m "added fx_new_function for numeric validation"`
4. push to your fork and open a pull request

## code style
- keep file names lowercase and use `snake_case`
- use consistent, descriptive comments at the top of each `.pq` or `.md` file
- maintain english naming in functions and queries
- avoid hard-coded paths; prefer relative references (e.g. `/data/sample/`)

## documentation
- add or update markdown files when introducing new queries or rules  
- document any new etl or validation logic in `/docs/`

## pull requests
- one logical change per pull request  
- include screenshots or sample outputs if relevant  
- check data consistency before submission  

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
