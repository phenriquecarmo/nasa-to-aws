package com.nasaws.nasaws.service.job

import com.nasaws.nasaws.service.messaging.NasaAwsService
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import java.time.LocalDateTime


@Component
class JobEmailSender(
    private val nasaAwsService: NasaAwsService
) {

    private val log = LoggerFactory.getLogger(this::class.java)

    @Scheduled(cron = "0 0 * * *", zone = "America/Sao_Paulo")
    fun myCronTask() {
        log.info("Running cronTask at ${LocalDateTime.now()}")
        nasaAwsService.postNasaImageOfDayMessageToSnsTopic()
    }
}