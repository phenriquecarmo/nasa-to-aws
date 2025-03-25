package com.nasaws.nasaws.nasapi

import org.springframework.beans.factory.annotation.Value
import org.springframework.http.HttpMethod
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate

@Service
class NasaPublicApiClient(
    @Value("\${clients.nasa_api_base_url}")
    private val baseUrl: String,
    @Value("\${clients.nasa_api_key}")
    private val nasaApiKey: String,
    private val restTemplate: RestTemplate
) {
    fun getImageOfTheDay(
        methodType: HttpMethod,
        date: String? = null
    ): Map<String, Any>? {
        val url = if (date != null) {
            "$baseUrl/planetary/apod?api_key=$nasaApiKey&date=$date"
        } else {
            "$baseUrl/planetary/apod?api_key=$nasaApiKey"
        }

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