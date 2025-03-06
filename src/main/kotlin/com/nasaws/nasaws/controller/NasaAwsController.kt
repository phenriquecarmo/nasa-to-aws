package com.nasaws.nasaws.controller

import com.nasaws.nasaws.service.NasaAwsService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/test/v1")
class NasaAwsController(
    @Autowired val nasaAwsService: NasaAwsService
) {

    @GetMapping
    fun checkServiceIsWorking(): String {
        return "Testing Controller from nasaws API"
    }

    @GetMapping("/nasa/iotd")
    fun getNasaImageOfTheDay(): Map<String, Any>? {
        val response = nasaAwsService.getNasaIOD()

        return response
    }

    @PostMapping("/nasa/iotd/send-message")
    fun getNasaImageOfTheDayAndPostToSnsTopic(): ResponseEntity<Void> {
        val response = nasaAwsService.postNasaImageOfDayMessageToSnsTopic()
        // Return later a request ID saved on S3
        return ResponseEntity.status(HttpStatus.CREATED).build()
    }

    @GetMapping("nasa/iotd/from-s3-bucket") // Retrieve the message with a specific ID from S3 Bucket
    fun getNasaImageOfTheDayFromS3() {
        // response =  s3Client.loadMessage()

        // return response
    }

}