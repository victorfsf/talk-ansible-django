# Talk: Django Ansible Playbook

Running the playbook:
```bash
cd deploy && ansible-playbook -i inventory -l production playbook.yml -e "branch=master"
```
