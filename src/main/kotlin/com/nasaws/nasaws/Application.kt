package com.nasaws.nasaws

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration
import org.springframework.boot.runApplication

@SpringBootApplication(
	exclude = [DataSourceAutoConfiguration::class, JpaRepositoriesAutoConfiguration::class]
)
class Application

fun main(args: Array<String>) {
	runApplication<Application>(*args)
}
