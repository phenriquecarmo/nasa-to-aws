package com.nasaws.nasaws.service

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.registerKotlinModule
import com.nasaws.nasaws.aws.sns.SnsClient
import com.nasaws.nasaws.nasapi.NasaPublicApiClient
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpMethod
import org.springframework.stereotype.Service

@Service
class NasaAwsService(
    @Autowired val nasaPublicApiClient: NasaPublicApiClient,
    @Autowired val snsClient: SnsClient
) {


    fun getNasaIOD(date: String? = null): Map<String, Any>? {
        val response = nasaPublicApiClient.getImageOfTheDay(HttpMethod.GET, date)

        return response
    }

    fun postNasaImageOfDayMessageToSnsTopic() {
        val objectMapper: ObjectMapper = ObjectMapper().registerKotlinModule()
        val response = getNasaIOD()

        val messageJson = objectMapper.writeValueAsString(response)

        messageJson?.let {
            snsClient.sendMessageToTopic(
                message = it
            )
        }
    }

}