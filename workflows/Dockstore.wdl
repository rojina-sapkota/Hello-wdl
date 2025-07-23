version 1.0

task say_hello {
    input {
        String greeting
        String name
    }

    command <<< 
        echo "~{greeting}, ~{name}!" 
    >>>

    output {
        String message = read_string(stdout())
    }

    runtime {
        cpu: 1
        memory: "1G"
        disks: "local-disk 1HDD"
        docker: "ubuntu:latest"  # Example Docker image
    }
}

workflow main {
    input {
        String name
        Boolean is_pirate = false
    }

    Array[String?] raw_greetings = [
        "Hello",
        "Hallo",
        "Hej",
        if is_pirate then "Ahoy" else None
    ]

    Array[String] greetings = remove_nulls(select_all(raw_greetings))

    scatter (greeting in greetings) {
        call say_hello {
            input:
                greeting = greeting,
                name = name
        }
    }

    output {
        Array[String] messages = say_hello.message
    }
}
