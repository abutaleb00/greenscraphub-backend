import express from "express";
import { auth } from "../middlewares/auth.js";
import {
    submitInquiry,
    getAllInquiries,
    updateInquiry,
    deleteInquiry
} from "../controllers/inquiryController.js";

const router = express.Router();

/* ============================================================
    PUBLIC CHANNELS (General & Corporate)
============================================================ */

/** * @route   POST /api/v1/inquiry/submit
 * @desc    Submit general contact or corporate leads
 * @access  Public
 */
router.post("/submit", submitInquiry);


/* ============================================================
    ADMIN/AGENT MANAGEMENT CONSOLE
============================================================ */

/** * @route   GET /api/v1/inquiry/list
 * @desc    Fetch and filter inquiries (type, status)
 * @access  Admin/Agent
 */
router.get("/list", auth(["admin", "agent"]), getAllInquiries);

/** * @route   PATCH /api/v1/inquiry/:id
 * @desc    Update inquiry status (read, contacted, resolved) or add admin notes
 * @access  Admin/Agent
 */
router.patch("/:id", auth(["admin", "agent"]), updateInquiry);

/** * @route   DELETE /api/v1/inquiry/:id
 * @desc    Permanently remove inquiry record
 * @access  Admin
 */
router.delete("/:id", auth(["admin"]), deleteInquiry);

export default router;