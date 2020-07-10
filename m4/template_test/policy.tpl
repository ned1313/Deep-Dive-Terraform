%{for rule in var.rules}
rule.path_type "${rule.path}" {
    policy = "${rule.policy}"
}
%{ endfor }
