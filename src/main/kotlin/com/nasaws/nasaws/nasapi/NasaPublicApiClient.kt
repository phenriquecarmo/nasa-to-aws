package com.nasaws.nasaws.nasapi

import jakarta.servlet.http.HttpServletRequest
import org.springframework.beans.factory.annotation.Value
import org.springframework.http.HttpMethod
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate
import org.springframework.web.client.exchange

@Service
class NasaPublicApiClient(
    @Value("\${clients.nasa_api_base_url}")
    private val baseUrl: String,
    @Value("\${clients.nasa_api_key}")
    private val nasaApiKey: String,
    private val restTemplate: RestTemplate
) {
    fun getImageOfTheDay(
        methodType: HttpMethod
    ): Map<String, Any>? {
        val url = "$baseUrl/planetary/apod?api_key=$nasaApiKey"

        val responseEntity = restTemplate.exchange(
            url,
            methodType,
            null,
            Map::class.java
        )

        return responseEntity.body?.let {
            it as Map<String, Any>?
        } ?: emptyMap()
    }

}